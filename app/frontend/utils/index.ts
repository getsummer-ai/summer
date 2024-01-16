export const preloadImage = async (
  url: string,
  callback?: (i: HTMLImageElement) => void,
): Promise<HTMLImageElement> => {
  const image = new Image();
  image.src = url;
  return new Promise((resolve, reject) => {
    image.onload = () => {
      if (!!callback) callback(image);
      resolve(image);
    };

    image.onerror = reject;
  });
};
