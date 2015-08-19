# encoding: utf-8

module GalleryHelper

  def galleria_link(picture)
    image = EspCommons::Image.new(:url => picture.try(:picture_url) || picture.try(:url)).parse_url
    return if !image || !image.image?
    thumbnail_url = image.create_thumbnail(:width => 200, :height => 128, :crop => true).url
    image_url = image.create_thumbnail(:width => 1050, :height => 700, :crop => true).url
    link_to image_tag(thumbnail_url, :alt => nil, :title => simple_format(picture.description)), image_url
  end

end
