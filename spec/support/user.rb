# Mock an ActiveRecord User model
class User
  attr_accessor :stripe_id

  def initialize(stripe_id:)
    @stripe_id = stripe_id
  end

  def update(stripe_id:)
    @stripe_id = stripe_id
    true
  end

  def save
    true
  end

  def valid?
    true
  end
end
