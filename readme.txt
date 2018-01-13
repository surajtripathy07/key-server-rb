Run app.rb to start the server

ruby app.rb

All the below are rest GET api's

'/' - to test if server is up
'/keys' - generates keys (free keys are maintained to 3)
'/free' - lists all the free keys
'/show' - returns the keys hash 
'/key' - blocks one key
'/key/unblock/:id' - unblocks the key 
'/key/delete/:id' - deletes the key
'/key/keep/:id' - keep's the passed key alive [re touches the key to ensure availability for next 5 minutes]
