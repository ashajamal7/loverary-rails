class Author < ApplicationRecord
  enum :gender, { male: 0, female: 1 }
end
