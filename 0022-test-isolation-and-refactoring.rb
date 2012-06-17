# In this screencast, Gary talks us through refactoring when testing in
# isolation. I have no particular problems with the content, but wanted
# to pick up on something which sets me off on one of my favourite ranting
# topics: mocks vs stubs.
#
# At around 4:50, we run into an issue where this test code:
#
it "integrates with dumbertree" do
  confirmation = stub
  Braintree::TransparentRedirect.stub(:confirm).with(query_string).
    and_return(confirmation)
  credit_card = ConfirmsTransparentRedirect.confirm!(query_string)
end

# Leads to a test failure where confirmation receives an unexpected message.
# Gary eventually solves the problem in the usual way - amending the invocation
# to `confirmation = stub.as_null_object`.
#
# The reason I see this as problematic is that there is no difference in RSpec
# between doubles created with the `mock`, `stub`, and `double` methods, yet
# we want to use mocks for different purposes than stubs. Stubs are objects
# which return canned responses to specified method calls to aid in testing;
# when working with stubs, we typically don't care whether other methods are
# called, nor what the responses to those method calls should be. By contrast,
# mocks are objects that allow us to assert on the messages sent to them. The
# fail-fast mocks that RSpec provides allow us to assert that no unexpected 
# messages get sent by failing as soon as they get an unexpected message. This
# is the behaviour we see here, and it is not, IMO, appropriate for a stub.
#
# To see an alternative solution to this problem, check out matahari[1], my
# implementation of the test spy pattern. I don't recommend you use it for
# anything serious, since it needs some work, but spies view things the other
# way round: by default, they are dumb stubs, receiving all method calls and
# returning nil unless a canned response has been specified, but then allowing
# assertions to be made later on about what messages were sent, including the
# assertion that a given message was not sent. So in this case, we'd be able to
# say:

it "integrates with dumbertree" do
  confirmation = spy
  Braintree::TransparentRedirect.stub(:confirm).with(query_string).
    and_return(confirmation)
  credit_card = ConfirmsTransparentRedirect.confirm!(query_string)
end

# and this would work without further modification since spies don't fail fast.
#
# Update: it seems that making double/stub as_null_object by default is mooted
# for RSpec 3: https://github.com/rspec/rspec-mocks/issues/56
#
# [1] https://github.com/mortice/matahari
