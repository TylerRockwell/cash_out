![Cash Out](assets/title-image.jpg)

A gem developed with the express purpose of reducing development time when integrating
with Stripe payments.

This gem is targeted at API development and assumes your frontend is able to generate
and send tokenized payment data to your endpoints.

## Contents
1. [Installation](#installation)
1. [Configuration](#configuration)
1. [Usage](#usage)
    1. [Handling Credit Cards](#creating-a-stripe-customer)
        1. [Creating a Stripe Customer](#creating-a-stripe-customer)
        1. [Deleting a Stripe Customer](#deleting-a-stripe-customer)
    1. [Handling Bank Accounts](#creating-a-stripe-connect-custom-account)
        1. [Creating a Stripe Connect Custom Account](#creating-a-stripe-connect-custom-account)
            1. [Further Reading](#further-reading)
        1. [Deleting a Stripe Connect Custom Account](#deleting-a-stripe-connect-custom-account)
    1. [Creating a Charge](#creating-a-charge)
        1. [Without a Payout](#without-a-payout)
        1. [With a Payout](#with-a-payout)
    1. [Creating a Transfer](#creating-a-transfer)


## Installation

1. Add `gem cash_out` to your Gemfile.
1. `bundle install`
1. `rails generate cash_out:install`
1. Update the items in `config/initializers/cash_out.rb` with your Stripe API keys.
1. Create a migration to add a `stripe_id` (String) field to `User` or whichever model will hold the Stripe token.
1. If using Stripe Connect (for making payouts), add `date_of_birth`(Date) to your `User` as well.

## Configuration
CashOut needs to be configured with your Stripe API keys. You can find the config file
in `config/initializers/cash_out.rb`. If it's not there, run `rails generate cash_out:install`.

```ruby
CashOut.configure do |config|
  config.stripe_publishable_key = 'your_stripe_public_key'
  config.stripe_secret_key = 'your_stripe_secret_key'
end
```

## Usage

All `CashOut` services utilize [ActiveInteraction](https://github.com/AaronLasseigne/active_interaction)
and will return an appropriate service object.

### Creating a Stripe Customer

Stripe Customer objects are used for making credit card purchases. You can create a
Stripe Customer and store the token on your User with the following code.

Sample Code:
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

Sample Code:
```ruby
def destroy
  CashOut::Payments::Customer::Delete.run(user: current_user)
end
```

Note: This currently deletes the entire Customer account. Support for deleting
individual cards will be added in a future release.

### Creating a Stripe Connect Custom Account

A Stripe Connect Custom Account is used when your app needs to pay independent
contractors. This will connect the user's bank account with a Stripe account
you create for them. This will allow you to make payments out to the user's account
and make transfers from the user's bank account to settle any outstanding balance.

Setting up a Connect Account requires several params. `user` can be any object
that responds to `stripe_id`, `valid?`, `save`, `date_of_birth`, `first_name`, and `last_name`.

| Param        | Description  |
:--------------|:------------:|
| **user** | The user receiving the account. It must respond to `stripe_id`, `valid?`, `save`, `date_of_birth`, `first_name`, and `last_name`
| **external_account_token** | Tokenized bank account info, generated via frontend app.
| **ip_address** | The user's current ip address. Can be accessed via `request.remote_ip`
| **legal_entity_type** | Must be `"individual"` or `"company"`
| **ssn_last_4** | The last 4 digits of the user's SSN
| **stripe_terms_accepted** | The frontend must link to the [Stripe Connected Account Agreement](https://stripe.com/connect-account/legal), and the user must accept it.
| **legal_entity_address** | The address of the individual user or the user's business. Must contain `line1`, `city`, `state`, `country`, and `postal_code`. `line2` is optional.

Sample Code:
```ruby
def create
  CashOut::Connect::Account::Create.run(account_params)
end

def account_params
  {
    user: current_user,
    external_account_token: params[:external_account_token],
    ip_address: ,
    legal_entity_type: params[:legal_entity_type],
    ssn_last_4: params[:ssn_last_4],
    stripe_terms_accepted: params[:stripe_terms_accepted],
    legal_entity_address: legal_entity_params
  }
end

def legal_entity_params
  params.require(:address).permit(
    :line1,
    :line2,
    :city,
    :state,
    :country,
    :postal_code
  )
end
```

#### Further Reading
Further documentation regarding Connect accounts may be found on
[Stripe's Official Connect Documentation](https://stripe.com/docs/api#account)

### Deleting a Stripe Connect Custom Account

To remove payment information from your user, run the appropriate delete service

Sample Code:
```ruby
def destroy
  CashOut::Connect::Account::Delete.run(user: current_user)
end
```

### Creating a Charge

#### Without a Payout
When creating a charge without a payout, you can send just 2 params

| Param        | Description  |
:--------------|:------------:|
| **payor** | The user being charged. It must respond to `stripe_id`. |
| **amount_to_charge** | The amount of money in cents to be charged. Must be a positive integer. |

**Example:**

```ruby
CashOut::Charge::Create.run(charge_params)

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
CashOut::Charge::Create.run(charge_params)

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

### Creating a Transfer
CashOut attempts to handle transfers automatically. However, should the case arise that you need to create
one manually, you can do so with the following.


| Param        | Description  |
:--------------|:------------:|
| **payee** | The user receiving payment. It also must respond to `stripe_id` |
| **amount_to_payout** | The amount of money in cents to be paid out. Must be an integer. |

```ruby
CashOut::Connect::Transfer::Create.run(transfer_params)

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
