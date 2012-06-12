#Code at the end of this screencast, annotated by me
class Walrus
  attr_reader :energy
  def initialize
    @energy = 0
  end

  def receive_gift!(gift)
    # XXX Tell Don't Ask
    # We ask the gift if it's edible, and then we tell it to (be) digested.
    # This smells to me. I don't like the idea of calling a query method as 
    # a guard around a command because of Tell Don't Ask.
    if gift.edible?
      @energy += gift.digest.energy
    end
  end
end

class LifeEvent
  attr_reader :energy

  def initialize(params)
    @energy = params.fetch(:energy)
  end
end

describe Walrus do
  it "gains energy by eating food" do
    cheese = stub(:edible? => true,
                  :digest => LifeEvent.new(:energy => 100))
    expect do
      subject.receive_gift!(cheese)
    end.to change { subject.energy }.by 100
  end

  it "ignores non-edible things" do
    shoe = stub(:edible? => false)
    expect do
      subject.receive_gift!(shoe)
    end.not_to change { subject.energy }
  end
end

# Let's see what we can do about this, changing only the stubbing in the tests 
# and the subject under test.
#
class TomsWalrus
  attr_reader :energy
  def initialize
    @energy = 0
  end

  def receive_gift!(gift)
    #"digest" didn't seem quite the right name for this command to me
    @energy += gift.when_digested.energy
  end
end

class LifeEvent
  attr_reader :energy

  def initialize(params)
    @energy = params.fetch(:energy)
  end
end

class NoChangeEvent
  def energy
    0
  end
end

describe TomsWalrus do
  it "gains energy by eating food" do
    cheese = stub(:when_digested => LifeEvent.new(:energy => 100))
    expect do
      subject.receive_gift!(cheese)
    end.to change { subject.energy }.by 100
  end

  it "gains no energy from non-edible things" do
    shoe = stub(:when_digested => NoChangeEvent.new)
    expect do
      subject.receive_gift!(shoe)
    end.not_to change { subject.energy }
  end
end

#From the point of view of results, this is equivalent. But now the walrus 
#tries to eat everything we give it. Implausible in real life, but in an 
#OO system, this seems a fair way of modelling things. It lets different 
#types of event dictate different behaviour - shoes and cheeses can return 
#these different events so that composing objects in a different way achieves 
#different results in the system.
