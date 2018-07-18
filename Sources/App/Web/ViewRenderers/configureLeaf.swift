import Leaf
import Flash

func configureLeaf(_ services: inout Services) {
    
    var tags = LeafTagConfig.default()
    
    tags.use(FlashTag(), as: "flash")
    
    tags.use(PrefixTag(), as: "prefix")
    
    services.register(tags)
}
