![Cash Out](assets/title-image.jpg)

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

## Configuration
CashOut needs to be configured with your Stripe api keys. You can find the config file
in `config/initializers/cash_out.rb`. If it's not there, run `rails generate cash_out:install`.

```ruby
CashOut.configure do |config|
  config.stripe_publishable_key = 'pk_your_stripe_public_key'
  config.stripe_secret_key = 'sk_your_stripe_secret_key'
end
```

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

### Creating a Charge

#### Without a Payout
When creating a charge without a payout, you can send just 2 params

| Param        | Description  |
:--------------|:------------:|
| **payor** | The user being charged. It must respond to `stripe_id`. |
| **amount_to_charge** | The amount of money in cents to be charged. Must be a positive integer. |

**Example:**

```ruby
CashOut::Charges::Create.run(charge_params)

def charge_params
  { payor: paying_user, amount_to_charge: charge_in_cents }
end
```

#### With a Payout
Making a charge with a payout is a little more complex, but CashOut aims to handle
the difficult parts for you. There are 4 params that need to be sent:

| Param        | Description  |
:--------------|:------------:|
| **payor** | The user being charged. It must respond to `stripe_id`. |
| **amount_to_charge** | The amount of money in cents to be charged. Must be a positive integer. |
| **payee** | The user receiving payment. It also must respond to `stripe_id` |
| **amount_to_payout** | The amount of money in cents to be paid out. Must be an integer. |

**Example:**

```ruby
CashOut::Charges::Create.run(charge_params)

def charge_params
  {
    payor: paying_user,
    amount_to_charge: charge_in_cents,
    payee: user_getting_paid,
    amount_to_payout: payout_in_cents
  }
end
```

It's important to know that `amount_to_payout` can be either positive or negative.

In the case of a positive payout, the user will receive the `amount_to_payout` in their Stripe account.
For negative payouts, the `amount_to_payout` will be transfered from the user to the platform (business owned)
Stripe account.

### Creating a standalone Transfer
CashOut attempts to handle transfers automatically. However, should the case arise that you need to create
one manually, you can do so with the following.


| Param        | Description  |
:--------------|:------------:|
| **payee** | The user receiving payment. It also must respond to `stripe_id` |
| **amount_to_payout** | The amount of money in cents to be paid out. Must be an integer. |

```ruby
CashOut::Transfer::Create.run(transfer_params)

def transfer_params
  {
    payee: user_getting_paid,
    amount_to_payout: payout_in_cents
  }
end
```

**Important Note** When creating a transfer without a corresponding payment, or when the transfer
amount exceeds the amount of associated charges, the platform Stripe account **MUST** have enough
available funds to cover the transfer, or the transfer will fail.
