class BuyersController < ApplicationController
  require 'payjp'
  before_action :set_card, :set_item


  def index
    @profile = current_user.profile
    @address = current_user.address
    #テーブルからpayjpの顧客IDを検索
    if @card.blank?
      #登録された情報がない場合にカード登録画面に移動
      redirect_to new_card_path
    else
      Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_SECRET_KEY]
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(@card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end

  def pay
    Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_SECRET_KEY]
    Payjp::Charge.create(
    :amount => @item.price, #支払金額を入力（itemテーブル等に紐づけても良い）@item.price,
    :customer => @card.customer_id, #顧客ID
    :currency => 'jpy', #日本円
  )

  @item.update(buyer_id: current_user.id)
  redirect_to action: 'done' #完了画面に移動
  end

  def set_card
    @card = Card.find_by(user_id: current_user)
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

end
