
(module png
	(with-image)
	(import lolevel bind chicken scheme foreign)


(bind* #<<EOF



#ifndef CHICKEN
#include <png.h>
#endif


void * open_image(char * file, ___out int *x, ___out int *y){

    png_image image;
    memset(&image, 0, (sizeof image));
    image.version = PNG_IMAGE_VERSION;
    *x = *y = 0;
    if (png_image_begin_read_from_file(&image, file)){
        png_bytep buffer;

        image.format = PNG_FORMAT_RGBA;

        buffer = malloc(PNG_IMAGE_SIZE(image));

        if(buffer != NULL && 
            png_image_finish_read(&image, NULL, buffer, 0, NULL))
            {
                 *x = image.width;
                 *y = image.height;
                 return buffer;
            }else{
                 if (buffer == NULL)
                     png_image_free(&image);
                 else
                     free(buffer);
            }
    }
    return NULL;
}

EOF
)



(define (with-image file proc)
  (let-values
      (((buff x y)
	(open_image file)))
      (let ((ret 
    (if (and (< 0 x) (< 0 y))
	(proc buff x y))))

    (free buff)
    ret)
    ))
)
