class UIImageView
  
  class ImageCache
    attr_accessor :cache
    def init
      a = super
      if  a
        NSNotificationCenter.defaultCenter.addObserver(self, selector: 'clearCache', name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
      end
      return a
    end

    def dealloc
      NSNotificationCenter.defaultCenter.removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    end

    def cache
      @cache ||= {}
    end

    def clearCache
      @cache.clear
    end

    def cachedImageForURL(url)
      cache[url]
    end
    
    def storeCachedImage(image,forURL:url)
       cache[url] = image
    end
    
  end

  class DownloadHelper
    attr_accessor :url,:data,:connection,:delegate,:image

    def connection
      @connection
    end

    def data
      @data||=NSMutableData.data
    end

    def connection(connection, didReceiveData: data)
       self.data.appendData(data)
      # print 'this is data ',!!data
    end

    def connectionDidFinishLoading(connection)
      #puts 'delegate method called'
      delegate.didCompleteDownloadForURL(image.url,withData:data)
    end

    def didCompleteDownloadForURL(url,withData:data)

      image = UIImage.imageWithData(data)
      return unless image

      imageCache = UIImageView.imageCache
      imageCache.storeCachedImage(image,forURL:url)
      self.image = image
    end

    def cancelConnection
      if connection
        connection.cancel
        connection = nil
      end
    end

    def dealloc
      cancelConnection
    end

  end

end

module RemoteFileHidden
  attr_accessor :url,:downloadHelper

  def UIImageView.imageCache
    @imageCache ||= UIImageView::ImageCache.alloc.init
  end


  def downloadHelper
    helper ||= UIImageView::DownloadHelper.alloc.init
    helper.delegate = helper
    helper.image = self
    @downloadHelper = helper
    @downloadHelper
  end





  def setImageWithRemoteFileURL(urlString,placeHolderImage:placeHolderImage)

    if self.url != nil && self.url == urlString
      return
    end

    self.url = urlString
    self.downloadHelper.url = urlString
    self.downloadHelper.cancelConnection


    imageCache = UIImageView.imageCache
    image = imageCache.cachedImageForURL(urlString)

    if image
      self.image = image
      return
    end

    self.image = placeHolderImage

    url = NSURL.URLWithString(urlString)
    request = NSURLRequest.requestWithURL(url)

    self.downloadHelper.url = urlString
    self.downloadHelper.connection = NSURLConnection.alloc.initWithRequest(request, delegate: self.downloadHelper, startImmediately: true)
    #puts downloadHelper.connection
    self.downloadHelper.data = NSMutableData.data if self.downloadHelper.connection



  end



end

class UIImageView
  include RemoteFileHidden
  alias_method :old_dealloc, :dealloc

  def dealloc
    downloadHelper.cancelConnection if url
    old_dealloc
  end
end