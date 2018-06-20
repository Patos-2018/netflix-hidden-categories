class NetflixTitle < ApplicationRecord
  has_many_and_belongs_to :genres
end
