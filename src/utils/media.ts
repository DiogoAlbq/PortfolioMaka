export function getYouTubeId(url: string): string | null {
  const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
  const match = url.match(regExp);
  return match && match[2].length === 11 ? match[2] : null;
}

export function getTikTokId(url: string): string | null {
  const match = url.match(/tiktok\.com\/.*video\/(\d+)/);
  return match ? match[1] : null;
}

export function getYouTubeThumbnail(url: string, quality: 'maxresdefault' | 'hqdefault' | 'mqdefault' | 'sddefault' = 'hqdefault'): string | null {
  const id = getYouTubeId(url);
  return id ? `https://img.youtube.com/vi/${id}/${quality}.jpg` : null;
}

export function isVideoUrl(url: string): boolean {
  return getYouTubeId(url) !== null || getTikTokId(url) !== null || url.match(/\.(mp4|webm|ogg|mov)$/i) !== null;
}

export function optimizeImageUrl(url: string, width?: number, quality = 80): string {
  if (url.includes('cloudinary.com')) {
    const uploadIndex = url.indexOf('/upload/');
    if (uploadIndex !== -1) {
      const transformations = width ? `w_${width},q_${quality},f_auto/` : `q_${quality},f_auto/`;
      return url.slice(0, uploadIndex + 8) + transformations + url.slice(uploadIndex + 8);
    }
  }
  if (url.includes('unsplash.com')) {
    const params = new URLSearchParams();
    if (width) params.set('w', width.toString());
    params.set('q', quality.toString());
    params.set('auto', 'format');
    params.set('fit', 'crop');
    const separator = url.includes('?') ? '&' : '?';
    return `${url}${separator}${params.toString()}`;
  }
  return url;
}

export function getMediaType(url: string): 'image' | 'video' | 'unknown' {
  if (getYouTubeId(url) || getTikTokId(url)) return 'video';
  if (url.match(/\.(jpg|jpeg|png|gif|webp|avif|svg)(\?.*)?$/i)) return 'image';
  if (url.match(/\.(mp4|webm|ogg|mov)(\?.*)?$/i)) return 'video';
  return 'unknown';
}