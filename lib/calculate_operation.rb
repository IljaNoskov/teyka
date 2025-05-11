class CalculateOperation

  attr_reader :user, :positions, :summ, :discount, :cashback

  def initialize(user_id, positions)
    @user = User.where(id: user_id).first
    @positions = positions.map { |product| parse_position(product) }
    @summ, @discount, @cashback = summ_discount_and_cash(@positions)
  end

  private

  def parse_position(item)
    product = Product.where(id: item['id']).first
    type = product ? product[:type] : nil
    value = product ? product[:value] : nil
    unless type == 'noloyalty'
      discount_percent = (type == 'discount' ? value.to_f : 0.0) + Template.where(id: @user[:template_id]).first[:discount]
      cash_persent = (type == 'increased_cashback' ? value.to_f : 0.0) + Template.where(id: @user[:template_id]).first[:cashback]
    else
      discount_percent = 0.0
      cash_persent = 0.0
    end

    { 
      id: item['id'],
      price: item['price'],
      quantity: item['quantity'],
      type: type,
      value: value,
      type_desc: decription(type, value),
      discount_percent: discount_percent,
      discount_summ: item['quantity'] * item['price'] * discount_percent / 100,
      cash_persent: cash_persent
    }
  end

  def decription(type, value)
    case type
    when 'discount'
      "Дополнительная скидка #{value}%"
    when 'increased_cashback'
      "Дополнительный кэшбек #{value}%"
    when 'noloyalty'
      'Не участвует в системе лояльности'
    end
  end
  
  def summ_discount_and_cash(positions)
    summ = 0
    discount_summ = 0
    cash_summ = 0
    can_bonus_summ = 0
    positions.each do |product|
      summ_delta = product[:quantity] * product[:price]
      summ += summ_delta
  
      discount_summ_delta = product[:type] == 'noloyalty' ? 0.0 : summ_delta * (product[:discount_percent] / 100)
      discount_summ += discount_summ_delta
  
      can_bonus_summ_delta = summ_delta - discount_summ_delta
      cash_summ += can_bonus_summ_delta * (product[:cash_persent] / 100) unless product[:type] == 'noloyalty'
      can_bonus_summ += can_bonus_summ_delta
    end
    discount_value = "#{(discount_summ * 100 / summ).round(2)}%"
    cash_value = (cash_summ * 100 / summ).round(2)
    summ = summ - discount_summ
    [
      summ,
      {
        summ: discount_summ,
        value: discount_value
      },
      {
        value: cash_value,
        bonus_summ: can_bonus_summ,
        summ: cash_summ
      }
    ]
  end
end
