require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'rack/contrib'

# Подключаемся к БД
DB = Sequel.sqlite('db/test.db')

Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }

use Rack::JSONBodyParser

post '/operation' do
  calc_op = CalculateOperation.new(params['user_id'], params['positions'])

  # Создаём новую операцию
  @op = Operation.create(
    user_id: calc_op.user[:id],
    cashback: calc_op.cashback[:summ],
    cashback_percent: calc_op.cashback[:value],
    discount: calc_op.discount[:summ],
    discount_percent: calc_op.discount[:value][0..-2].to_f,
    check_summ: calc_op.summ,
    done: false,
    allowed_write_off: calc_op.cashback[:bonus_summ]
  )

  # приводим информацию о бонусах в нужный вид
  cashback = {
    existed_summ: calc_op.user[:bonus].to_f,
    allowed_summ: [calc_op.user[:bonus].to_f, calc_op.cashback[:bonus_summ]].min,
    value: "#{calc_op.cashback[:value]}%",
    will_add: calc_op.cashback[:summ].round()
  }

  # Возвращаем ответ
  content_type :json
  status 200
  {
    status: 200,
    user: calc_op.user.to_hash,
    operation_id: @op[:id],
    summ: calc_op.summ,
    positions: calc_op.positions.map { |item| item.except(:cash_persent) },
    discount: calc_op.discount,
    cashback: cashback
  }.to_json
end

post '/submit' do
  @user = User.where(id: params['user']['id']).first
  @operation = Operation.where(id: params['operation_id'], user_id: params['user']['id']).first

  @operation.update(write_off: params['write_off'], done: true)

  content_type :json
  status 200
  {
    status: 200,
    user: @user[:id],
    message: "Данные успешно обработаны!",
    operation: @operation.to_hash.except(:id, :done, :allowed_write_off).transform_values(&:to_f)
  }.to_json
end
