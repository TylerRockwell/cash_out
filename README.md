# Cash Out

A gem developed with the express purpose of reducing development time when integrating
with Stripe payments.

This gem is targeted at API development and assumes your frontend is able to generate
and send tokenized payment data to your endpoints.

## Installation

1. Add `gem cash_out` to your Gemfile
1. `bundle install`
1. `rails generate cash_out:install`
1. Update the items in `config/initializers/cash_out.rb` with your Stripe api keys
1. Create a migration to add a `stripe_id` field to `User` or whichever model will hold the Stripe token

## Usage

All `CashOut` services utilize [ActiveInteraction](https://github.com/AaronLasseigne/active_interaction)
and will return an appropriate service object.

### Creating a Stripe Customer

Stripe Customer objects are used for making credit card purchases. You can create a
Stripe Customer and store the token on your User with the following code.

Inside your controller, add:
```ruby
def create
  CashOut::Payments::Customer::Create.run(customer_params)
end

def customer_params
  { user: current_user, stripe_token: params[:token] }
end
```

### Deleting a Stripe Customer

To remove payment information from your user, run the appropriate delete service

Inside your controller, add:
```ruby
def destroy
  CashOut::Payments::Customer::Delete.run(user: current_user)
end
```

Note: This currently does not delete the payment information from Stripe. Support
for this will be added in a future release.
