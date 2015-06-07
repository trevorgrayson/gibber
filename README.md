#Gibber

Configuration woes?  Leave it to The Gipper!

```ruby
hash_of_configs = {
  a: "some variable",
  b: "some other variable",
  c: 1234,
  d: "bob"
}

Gipper.new hash_of_configs, ENV do
  verify :a, :b, :c, :d
end

```
