# Mock an ActiveRecord User model
class User
  attr_accessor :stripe_id, :date_of_birth, :first_name, :last_name

  def initialize(
    stripe_id: nil,
    date_of_birth: Date.new(1980, 1, 2),
    first_name: 'Riley',
    last_name: 'Bancroft'
  )
    @stripe_id = stripe_id
    @date_of_birth = date_of_birth || Date.new(1980, 1, 2)
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
