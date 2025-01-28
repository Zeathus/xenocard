from PIL import Image
from os import listdir, makedirs
from os.path import join, isfile, isdir
from tqdm import tqdm

dirs_to_convert = [
    "card_images",
    "card_images_baked"
]

all_files = []

def get_all_png_files(d):
    png_files = []
    for fname in listdir(d):
        fpath = join(d, fname)
        if isdir(fpath):
            png_files += get_all_png_files(fpath)
        elif isfile(fpath) and fname[fname.rindex("."):] == ".png":
            png_files.append(fpath)
    return png_files

for d in dirs_to_convert:
    all_files += get_all_png_files(f"../{d}")

for png_fpath in tqdm(all_files):
    jpg_fpath = png_fpath[1:].replace(".png", ".webp")
    jpg_dir = jpg_fpath[:jpg_fpath.rindex("/")]
    makedirs(jpg_dir, exist_ok=True)
    img = Image.open(png_fpath)
    #img = img.convert("RGB")
    img.save(jpg_fpath)
