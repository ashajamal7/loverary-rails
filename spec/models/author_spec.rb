require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'enums' do
    it { should define_enum_for(:gender).with_values(male: 0, female: 1) }
  end

  describe 'associations' do
    it { should have_many(:books).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:male_author) { create(:author, gender: :male) }
    let!(:female_author) { create(:author, gender: :female) }

    it 'returns male authors' do
      expect(Author.male).to include(male_author)
      expect(Author.male).not_to include(female_author)
    end

    it 'returns female authors' do
      expect(Author.female).to include(female_author)
      expect(Author.female).not_to include(male_author)
    end
  end

  describe 'callbacks' do
    let(:author) { build(:author, name: '  John Doe  ') }
    
    it 'strips whitespace from name before saving' do
      author.save
      expect(author.name).to eq('John Doe')
    end
  end
end
