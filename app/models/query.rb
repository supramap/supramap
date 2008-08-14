class Query < ActiveRecord::Base
  belongs_to :job
  
  # validate that if position is present, that it's a number
  # validate that ancestral and descendent state aren't the same

  AD_TYPES = [ "", "A", "C", "G", "T", "AG", "CT", "CG", "AT", "GT", "AC", "CGT", "AGT", "ACT", "ACG", "ACGT" ]

  INSDES = [
    [ "", "" ],
    [ "Insertion", "i" ],
    [ "Deletion", "d"]
  ]
  attr_accessor :anc_state, :desc_state, :position, :insdel

end
