require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { build(:category) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(50) }
    
    it 'validates name format' do
      valid_names = ['Fiction', 'Science Fiction', 'Non-Fiction', "Children's Books"]
      invalid_names = ['  ', 'a' * 51, 'Tech@Books', '']
      
      valid_names.each do |name|
        category.name = name
        expect(category).to be_valid
      end
      
      invalid_names.each do |name|
        category.name = name
        expect(category).not_to be_valid
      end
    end
    
    it 'strips whitespace from name before validation' do
      category = build(:category, name: '  Fantasy  ')
      category.valid?
      expect(category.name).to eq('Fantasy')
    end
  end

  describe 'callbacks' do
    context 'before_save' do
      it 'titleizes the name' do
        category = create(:category, name: 'science fiction')
        expect(category.name).to eq('Science Fiction')
      end
      
      it 'does not modify an already titleized name' do
        category = create(:category, name: 'Science Fiction')
        expect(category.name).to eq('Science Fiction')
      end
    end
  end

  describe 'scopes' do
    let!(:fiction) { create(:category, name: 'Fiction') }
    let!(:non_fiction) { create(:category, name: 'Non-Fiction') }
    
    describe '.alphabetical' do
      it 'returns categories in alphabetical order' do
        expect(Category.alphabetical).to eq([fiction, non_fiction])
      end
    end
    
    describe '.search' do
      it 'returns categories matching the search term' do
        expect(Category.search('Fic')).to include(fiction)
        expect(Category.search('Fic')).not_to include(non_fiction)
      end
      
      it 'is case insensitive' do
        expect(Category.search('fic')).to include(fiction)
      end
      
      it 'returns all categories when search term is blank' do
        expect(Category.search('').count).to eq(2)
      end
    end
  end
  
  describe 'instance methods' do
    describe '#to_s' do
      it 'returns the category name' do
        category = build(:category, name: 'Mystery')
        expect(category.to_s).to eq('Mystery')
      end
    end
    
    describe '#book_count' do
      it 'returns the number of books in this category' do
        category = create(:category)
        create_list(:book, 3, categories: [category])
        expect(category.book_count).to eq(3)
      end
      
      it 'returns 0 when there are no books' do
        category = create(:category)
        expect(category.book_count).to eq(0)
      end
    end
  end
  
  describe 'class methods' do
    describe '.most_popular' do
      it 'returns categories with the most books first' do
        popular = create(:category)
        less_popular = create(:category)
        create_list(:book, 3, categories: [popular])
        create_list(:book, 1, categories: [less_popular])
        
        expect(Category.most_popular.first).to eq(popular)
        expect(Category.most_popular.last).to eq(less_popular)
      end
    end
  end
end
