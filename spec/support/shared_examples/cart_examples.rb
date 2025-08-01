# frozen_string_literal: true

RSpec.shared_examples "adds an item to the cart successfully" do
  let(:book3) { create(:book, stock: 9) }

  it 'adds a valid, unique item to the cart' do
    post "/users/#{user.id}/cart/add", params: { items: [{  book_id: book3.id, quantity: 1, price: book3.price }] }
    expect(response).to have_http_status(:ok)

    cart = JSON.parse(response.body, symbolize_names: true)[:cart]
    expect(cart[:count]).to eq(1)
    expect(cart[:items][0][:book_id]).to eq(book3.id.to_s)
    expect(JSON.parse(response.body, symbolize_names: true)[:message]).to eq("successfully added item/s to cart")
  end
end
