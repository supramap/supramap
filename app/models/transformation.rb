class Transformation < ActiveRecord::Base
    set_inheritance_column :ruby_type
  belongs_to :treenode
end
