module VideoHelper
  def youtube_object(code)
    code = strip_tags(code)
    youtube_link = "http://www.youtube.com/watch?v=#{code}"

    VideoInfo.new(youtube_link)
  end
end
