# spec/models/order_item_spec.rb
require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let(:user) { create(:user) }
  let(:book) { create(:book, price: 10.0) }
  let(:order) { create(:order, user: user) }
  let(:order_item) { create(:order_item, order: order, book: book, quantity: 2, price: book.price) }

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'sets price from book if not provided' do
        new_item = build(:order_item, order: order, book: book, price: nil)
        new_item.valid?
        expect(new_item.price).to eq(book.price)
      end

      it 'uses provided price even if book has a different price' do
        custom_price = 15.0
        new_item = build(:order_item, order: order, book: book, price: custom_price)
        expect(new_item.price).to eq(custom_price)
      end
    end

    context 'before_save' do
      it 'calculates total price' do
        order_item.quantity = 3
        order_item.save
        expect(order_item.total_price).to eq(30.0)
      end
    end
  end

  describe '#update_order_total' do
    it 'updates the order total when order item is saved' do
      # Reset order total to 0 for this test
      order.update!(total_price: 0)
      
      expect {
        create(:order_item, order: order, book: book, quantity: 2, price: 10.0)
      }.to change { order.reload.total_price }.by(20.0)
    end

    it 'updates the order total when order item is updated' do
      order_item
      expect {
        order_item.update(quantity: 3)
      }.to change { order.reload.total_price }.by(10.0) # 30 - 20 = 10
    end

    it 'updates the order total when order item is destroyed' do
      order_item
      expect {
        order_item.destroy
      }.to change { order.reload.total_price }.by(-20.0)
    end
  end
end