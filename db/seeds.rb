# Clear existing data
puts "Clearing existing data..."
[OrderItem, Shipping, Review, Order, Book, Author, Category, User].each do |model|
  model.destroy_all
end

# Create sample categories
puts "Creating categories..."
categories = [
  "Fiction", "Non-Fiction", "Science Fiction", "Fantasy", "Mystery",
  "Romance", "Thriller", "Biography", "History", "Science"
].map { |name| Category.find_or_create_by!(name: name) }

# Create sample authors
puts "Creating authors..."
authors = [
  { name: "Leo Tolstoy", gender: 0 },
  { name: "Fyodor Dostoevsky", gender: 0 },
  { name: "Leo Tolstoy", gender: 0 } # Duplicate for multiple works
].map { |attrs| Author.find_or_create_by!(name: attrs[:name]).tap { |a| a.update!(gender: attrs[:gender]) } }

# Create sample books with cover images
puts "Creating books..."

def attach_cover(book, filename)
  # Set the cover_url to the path relative to public/storage
  book.cover_url = "covers/#{filename}"
end

books = [
  {
    title: "War and Peace",
    author: authors[0],
    isbn: "9780143039993",
    stock: 25,
    price: 14.99,
    summary: "A masterpiece of world literature, War and Peace is a historical novel set during the Napoleonic Wars, following the fates of five aristocratic families.",
    published_date: Date.new(1869, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 1392,
    average_rating: 4.2,
    cover_file: "war_and_peace.jpeg"
  },
  {
    title: "Anna Karenina",
    author: authors[0],
    isbn: "9780143035008",
    stock: 30,
    price: 12.99,
    summary: "A complex novel in eight parts, with more than a dozen major characters, it is spread over more than 800 pages, typically contained in two volumes.",
    published_date: Date.new(1878, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 964,
    average_rating: 4.1,
    cover_file: "anna_karenina.png"
  },
  {
    title: "The Kingdom of God Is Within You",
    author: authors[0],
    isbn: "9780486451381",
    stock: 15,
    price: 10.99,
    summary: "Tolstoy's philosophical treatise on nonviolent resistance, which profoundly influenced Mahatma Gandhi and Martin Luther King Jr.",
    published_date: Date.new(1894, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 352,
    average_rating: 4.3,
    cover_file: "Tolstoy-Kingdom-cover-half-scaled.jpg"
  },
  {
    title: "Resurrection",
    author: authors[0],
    isbn: "9780140446182",
    stock: 20,
    price: 11.99,
    summary: "Tolstoy's last completed novel, telling the story of a nobleman's attempt to redeem himself for the suffering his youthful philandering caused a woman.",
    published_date: Date.new(1899, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 492,
    average_rating: 4.0,
    cover_file: "resurrection.jpg"
  },
  {
    title: "Crime and Punishment",
    author: authors[1],
    isbn: "9780143107637",
    stock: 35,
    price: 13.99,
    summary: "A novel about the mental anguish and moral dilemmas of Rodion Raskolnikov, an impoverished ex-student in Saint Petersburg who formulates a plan to kill an unscrupulous pawnbroker.",
    published_date: Date.new(1866, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 671,
    average_rating: 4.3,
    cover_file: "crime_and_punishment.jpg"
  },
  {
    title: "The Brothers Karamazov",
    author: authors[1],
    isbn: "9780374528379",
    stock: 28,
    price: 16.99,
    summary: "A passionate philosophical novel set in 19th-century Russia, that enters deeply into the ethical debates of God, free will, and morality.",
    published_date: Date.new(1880, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 796,
    average_rating: 4.4,
    cover_file: "the_brothers_karamazov.jpg"
  },
  {
    title: "Notes from Underground",
    author: authors[1],
    isbn: "9780679734529",
    stock: 22,
    price: 9.99,
    summary: "A novel which portrays the life of a man who is a retired civil servant living in St. Petersburg, and his alienation from society.",
    published_date: Date.new(1864, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 136,
    average_rating: 4.2,
    cover_file: "notes_from_the_underground.jpeg"
  },
  {
    title: "Demons",
    author: authors[1],
    isbn: "9780141441412",
    stock: 18,
    price: 14.99,
    summary: "A political and philosophical novel that explores the consequences of nihilism and the dangers of revolutionary ideas.",
    published_date: Date.new(1872, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 733,
    average_rating: 4.2,
    cover_file: "devils.jpg"
  },
  {
    title: "A Confession",
    author: authors[0],
    isbn: "9780486431680",
    stock: 14,
    price: 8.99,
    summary: "Tolstoy's memoir of mid-life spiritual crisis and awakening, which led to his conversion to a form of Christian anarchism.",
    published_date: Date.new(1882, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 96,
    average_rating: 4.2,
    cover_file: "a_confession.jpg"
  },
  {
    title: "The Death of Ivan Ilyich",
    author: authors[0],
    isbn: "9780141192207",
    stock: 20,
    price: 7.99,
    summary: "A novella about the life and death of a high-court judge in 19th-century Russia, and his struggle to come to terms with his impending death.",
    published_date: Date.new(1886, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 92,
    average_rating: 4.2,
    cover_file: "the_death_of_ivan_ilych.jpeg"
  },
  {
    title: "Lives and Deaths",
    author: authors[0],
    isbn: "9780241454716",
    stock: 16,
    price: 10.99,
    summary: "A collection of Tolstoy's short stories exploring themes of life, death, and the human condition.",
    published_date: Date.new(2020, 1, 1),
    edition: 1,
    language: "Russian",
    page_count: 240,
    average_rating: 4.0,
    cover_file: "lives_and_deaths.jpeg"
  }
]

books.each do |book_attrs|
  cover_file = book_attrs.delete(:cover_file)
  # Assign a random category to the book
  book_attrs[:category] = categories.sample
  book = Book.create!(book_attrs)
  attach_cover(book, cover_file) if cover_file
end

# Create sample users
puts "Creating users..."
users = [
  {
    username: "johndoe",
    email: "john@example.com",
    password: "password",
    gender: 0
  },
  {
    username: "janedoe",
    email: "jane@example.com",
    password: "password",
    gender: 1
  }
].map do |user_attrs|
  User.create!(
    username: user_attrs[:username],
    email: user_attrs[:email],
    password: user_attrs[:password],
    gender: user_attrs[:gender]
  )
end

# Create sample orders
puts "Creating orders..."
statuses = [0, 1, 2, 3] # pending, paid, shipped, delivered

5.times do |i|
  user = users.sample
  order = Order.create!(
    user: user,
    status: statuses.sample,
    total_price: 0
  )

  # Add 1-3 random books to the order
  book_count = rand(1..3)
  books = Book.order("RANDOM()").limit(book_count)

  order_total = 0
  books.each do |book|
    quantity = rand(1..3)
    price = book.price * quantity
    order_total += price

    OrderItem.create!(
      order: order,
      book: book,
      quantity: quantity,
      price: book.price
    )

    # Update book stock
    book.update!(stock: book.stock - quantity)
  end

  # Update order total
  order.update!(total_price: order_total.round(2))

  # Create shipping if order is not pending
  # Create shipping if order is not pending (status 0)
  unless order.status == 0
    # Map order status to shipping status
    shipping_status = case order.status
    when 1 then 'processing' # paid
    when 2 then 'shipped' # shipped
    when 3 then 'delivered' # delivered
    when 4 then 'cancelled' # cancelled
    else 'pending' # default case
    end

    Shipping.create!(
      order: order,
      address: "#{Faker::Address.street_address}, #{Faker::Address.city}",
      status: shipping_status,
      tracking_code: "TRK#{SecureRandom.hex(8).upcase}",
      shipped_at: order.status == 3 ? Time.current - rand(1..10).days : nil
    )
  end
end

# Create sample reviews
puts "Creating reviews..."
50.times do
  book = Book.order("RANDOM()").first
  user = User.order("RANDOM()").first

  Review.create!(
    title: Faker::Book.title,
    comment: Faker::Lorem.paragraph(sentence_count: 3),
    rating: rand(1..5),
    user: user,
    book: book
  )

  # Update book's average rating
  book.update_average_rating
end

puts "Seeding completed successfully!"
puts "Seeding completed successfully!"
