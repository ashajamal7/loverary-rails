require 'rails_helper'

RSpec.describe Shipping, type: :model do
  let(:order) { create(:order) }
  let(:shipping) { create(:shipping, order: order) }

  describe 'associations' do
    it { should belong_to(:order) }
  end

  describe 'enums' do
    it 'defines status enum' do
      should define_enum_for(:status)
        .with_values(pending: 1, enroute: 2, delivered: 3)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:address) }
    it { should validate_length_of(:address).is_at_most(500) }
    it { should validate_presence_of(:tracking_code) }
    it { should validate_uniqueness_of(:tracking_code).case_insensitive }
    
    it 'validates tracking code format' do
      valid_codes = ['TRK12345', 'TRK-ABC-123', 'TRK_XYZ_456']
      invalid_codes = ['trk123', 'INVALID', '12345678', '']
      
      valid_codes.each do |code|
        shipping.tracking_code = code
        expect(shipping).to be_valid
      end
      
      invalid_codes.each do |code|
        shipping.tracking_code = code
        expect(shipping).not_to be_valid
      end
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'generates a tracking code if not present' do
        shipping = build(:shipping, tracking_code: nil)
        expect { shipping.save! }.to change { shipping.tracking_code }.from(nil)
        expect(shipping.tracking_code).to match(/^TRK[A-Z0-9]{10}$/)
      end

      it 'does not change existing tracking code' do
        shipping = create(:shipping, tracking_code: 'TRK12345678')
        expect { shipping.update!(address: 'New Address') }
          .not_to change { shipping.reload.tracking_code }
      end
    end

    context 'after_save' do
      it 'updates order status when shipping is delivered' do
        shipping = create(:shipping, status: :enroute)
        expect {
          shipping.update!(status: :delivered, delivered_at: Time.current)
        }.to change { shipping.order.reload.status }.to('completed')
      end
    end
  end

  describe 'scopes' do
    let!(:pending_shipment) { create(:shipping, status: :pending) }
    let!(:enroute_shipment) { create(:shipping, :enroute) }
    let!(:delivered_shipment) { create(:shipping, :delivered) }

    it 'returns pending shipments' do
      expect(Shipping.pending).to contain_exactly(pending_shipment)
    end

    it 'returns enroute shipments' do
      expect(Shipping.enroute).to contain_exactly(enroute_shipment)
    end

    it 'returns delivered shipments' do
      expect(Shipping.delivered).to contain_exactly(delivered_shipment)
    end
  end

  describe 'instance methods' do
    describe '#mark_as_delivered' do
      it 'updates status to delivered and sets delivered_at' do
        shipping = create(:shipping, :enroute, delivered_at: nil)
        
        Timecop.freeze do
          expect {
            shipping.mark_as_delivered
          }.to change { shipping.status }.to('delivered')
            .and change { shipping.delivered_at }.from(nil).to(Time.current)
        end
      end
    end

    describe '#delivery_time' do
      it 'returns the time between shipped and delivered' do
        shipping = create(:shipping, :delivered,
          shipped_at: 2.days.ago,
          delivered_at: 1.day.ago
        )
        expect(shipping.delivery_time).to eq(1.day)
      end

      it 'returns nil if not delivered' do
        shipping = create(:shipping, :enroute, delivered_at: nil)
        expect(shipping.delivery_time).to be_nil
      end
    end
  end
end
