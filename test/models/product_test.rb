require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  test "Product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "Product price must be positive" do
    product = Product.new(title:        "This is book",
                          description:  "This is a good book",
                          image_url:    "book.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
    product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
    product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title:        "This is book",
              description:  "This is a good book",
              image_url:    image_url,
              price:        10)
  end

  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.jpg
          http://a.b.c/x/y/z/fred.gif }
    bad = %w{fred.doc fred.gif/more fred.gif.more }
    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end
    bad.each do |name|
      assert new_product(name).invalid? "#{name} shouldn't be valid"
    end
  end

  test "product is not valid without a unique title - i18n" do
    product = Product.new(title:        products(:ruby).title,
                          description:  "yyy",
                          price:        1,
                          image_url:    "url.jpg")
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
                  product.errors[:title]
  end

  test "product title is at least 10 characters" do
    product = Product.new(title:        "this is at least 10",
                          description:  "yyy",
                          price:        1,
                          image_url:    "url.jpg")
    assert product.valid?

    product.title = 'not 10'
    assert product.invalid?
  end
end
