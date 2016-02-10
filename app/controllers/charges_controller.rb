class ChargesController < ApplicationController

  def create
    customer = Stripe::Customer.create(
      email: current_user.email,
      card: params[:stripeToken]
    )
    if current_user.standard?
      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: 15_00,
        description: "Premium Wiki Membership - #{current_user.email}",
        currency: 'usd'
      )
      current_user.update_attributes!( role: 'premium')
      flash[:notice] = "Thanks for upgrading, #{current_user.email}!"
      redirect_to wikis_path
    end

  rescue Stripe::CardError => e
    flash.now[:alert] = e.message
    redirect_to new_charge_path
  end

  def new
    if current_user.standard?
      @stripe_btn_data = {
        key: "#{ Rails.configuration.stripe[:publishable_key] }",
        description: "Premium Wiki Membership - #{current_user.name}",
        amount: 15_00
      }
    end
  end


end
