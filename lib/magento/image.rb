require 'magento/base'

module Mage
  class Image < Mage::Base
    
    cattr_accessor :uri
    attr_accessor :api
    
    def create!
    end
    
    def not_exist?
      true
    end
    
    

  end

end

#ec2log "Telechargement des images dans #{imgdir}..."
#ec2cmd "mkdir #{imgdir}"
#ec2cmd "picasa=\"#{picasa}\"", NO_LOG
#ec2cmd "wget -P#{imgdir} -q \"$picasa\" -O - | sed \"s/>/>\\n/g\" | grep \"^<enclosure\" | sed -e \"s/.*url='//\" -e \"s/' length.*//\" | while read url; do wget -P#{imgdir} $url; done"
#ec2log "... fin de telechargement des images."


