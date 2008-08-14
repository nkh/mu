
$*OUT.FETCH.print("1..2\n");

# Here we create the outer lexicalscopes
my $outer_scope = $SMOP__S1P__LexicalScope.new();

# Here's the value that should be fetched, because it was there at closure
# creation time.
$outer_scope.items.{"$_"}.STORE("ok 1");

# when the outer block is executed, the inner scope for the code
# object is created and linked to the outer scope.
my $inner_scope = $SMOP__S1p__LexicalScope.new();
$inner_scope.outer.STORE($outer_scope);

# The signature is bound at .() time, and at this point the value should be
# saved in the inner scope.
$SMOP__S1P__DefaultBlockSignature.BIND(\(), $inner_scope);

# To make sure the bind worked as expected, let's change the value in the outer
# scope. The inner scope should be a different variable, so the lookup should get its
# own value
$outer_scope.items.{"$_"}.STORE("not ok 1");

# Now we make a lookup in the inner scope, to make sure it takes the correct value.
$*OUT.FETCH.print($inner_scope.lookup("$_"));

# And now a last test which is to send a value in the capture, which should be set in
# the inner scope.
$SMOP__S1P__DefaultBlockSignature.BIND(\("ok 2"), $inner_scope);

# And now we make the lookup.
$*OUT.FETCH.print($inner_scope.lookup("$_");
