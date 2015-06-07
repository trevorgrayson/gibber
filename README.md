#The Gipper

Using environment variables? Using Docker? 

Sick of not knowing a configuration isn't set, or having your app blow up unexpectedly mid-execution?

Configuration woes?  Leave it to The Gipper! Trust OR Verify!

Try throwing the following Gipper block into application.rb, or your app's boot.

ENV variables will be used by default.  You may pass as many hashes as you want into the new method to override values.

Use the `trust` method if you would like to throw a warning message in the log.

Use the `verify` method if you would like to throw an error message in the log, and raise an error.

```ruby
hash_of_configs = {
  a: "some variable",
  b: "some other variable",
  c: 1234,
  d: "peter",
  e: "thorton"
}

Gipper.new hash_of_configs, ENV do
  trust :e 
  verify :a, :b, :c, :d
end

```


You may change the logger that Gipper uses by setting the logger.

```ruby
Gipper.logger = Logger.new(STDOUT)
```
