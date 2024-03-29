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
    # a guard around a command because if it's not edible, it should behave
    # in a different way when digested, rather than forcing all its
    # collaborators to check its edible? query method before calling its
    # digest method.
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
#
#Also notice I've introduced a Demeter violation - gift.when_digested.energy.
#I could deal with this in one of two ways - either allow events to be added 
#to Fixnums using Ruby magic, or apply tell don't ask further with something like:
#
def receive_gift!(gift)
  gift.be_digested_by(self)
end

class Shoe
  def be_digested_by(eater)
    #no op
  end
end

class Cheese
  def be_digested_by(eater)
    eater.receive_energy(100)
  end
end

#But this is getting into very abstract territory and making me scream out for 
#multimethods, so I've probably made a misstep somewhere.
