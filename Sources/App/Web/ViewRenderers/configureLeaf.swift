import Leaf

func configureLeaf(_ services: inout Services) {
    
    var defaultTags = LeafTagConfig.default()
    defaultTags.use(PrefixTag(), as: "prefix")
    
    services.register(defaultTags)
}
