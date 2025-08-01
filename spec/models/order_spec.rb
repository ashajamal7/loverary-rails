# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { create(:user) }
  let(:book) { create(:book, price: 10.0) }  # Set a fixed price for consistent testing
  let(:order) { create(:order, user: user, total_price: 0) }  # Start with 0 total_price

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:books).through(:order_items) }
  end

  describe 'validations' do
    it 'validates presence of status' do
      order = Order.new(user: user, total_price: 0)
      order.status = nil
      order.valid?
      expect(order.errors[:status]).to include("can't be blank")
    end

    it 'validates presence of total_price' do
      order = Order.new(user: user, status: :pending)
      order.total_price = nil
      order.valid?
      expect(order.errors[:total_price]).to include("can't be blank")
    end

    it 'validates numericality of total_price' do
      order = Order.new(user: user, total_price: -1)
      order.valid?
      expect(order.errors[:total_price]).to include('must be greater than or equal to 0')
    end

    it 'defines status enum with correct values' do
      should define_enum_for(:status).with_values(
        pending: 0,
        processing: 1,
        completed: 2,
        cancelled: 3
      ).with_prefix
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'sets default status to pending' do
        new_order = Order.new(user: user)
        new_order.valid?
        expect(new_order.status).to eq('pending')
      end
    end
  end

  describe '#add_book' do
    it 'adds a book to the order' do
      expect {
        order.add_book(book, 1)
      }.to change(order.order_items, :count).by(1)
    end

    it 'updates total price when adding a book' do
      expect(order.total_price).to eq(0)  # Starts at 0
      expect {
        order.add_book(book, 2)  # 2 * 10.0 = 20.0
      }.to change(order, :total_price).from(0).to(20.0)
    end
  end

  describe '#complete!' do
    it 'updates status to completed' do
      order.complete!
      expect(order.status).to eq('completed')
    end
  end

  describe '#cancel!' do
    it 'updates status to cancelled' do
      order.cancel!
      expect(order.status).to eq('cancelled')
    end
  end
end