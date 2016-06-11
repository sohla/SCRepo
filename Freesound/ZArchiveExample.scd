(
p = PathName.new("~/Music/archiveTest").absolutePath;
a = ZArchive.write(p);
a.writeItem(
    IdentityDictionary[
        \a -> "b",
		\b -> (\s : 123 ,\t : 5676),
		\sourcePath -> "~/Music/Somewhere/awesome/*",
		\someCode -> {|a| "hello %".format(a).postln}

]);
a.writeClose;
)

(
p = PathName.new("~/Music/archiveTest").absolutePath;
b =  ZArchive.read(p);
c = b.readItem;
b.close;

c.at(\a).postln;
c.at(\b)[\s].postln;
c.at(\sourcePath).postln;
c.at(\someCode).("world");
c.inspect;
)

