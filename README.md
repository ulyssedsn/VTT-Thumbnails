
![license](https://img.shields.io/github/license/ulyssedsn/VTT-Thumbnails.svg)
![pr_open](https://img.shields.io/github/issues-pr/ulyssedsn/VTT-Thumbnails.svg)
# VTT-Thumbnails

I love thumbnails, and I think that everybody needs thumbnails in his life. I have built 
for you an application that is able to generate giving a mp4 file, VTT Thumbnails (this
include the mosaic and the webvtt file). Enjoy !

## Installation

Use the package manager [bundler](https://bundler.io/) to install all
dependencies.

```bash
bundle install
bundle exec rails c
```

## Usage

```ruby
Thumbnails.new(<mp4_file>).call
```
## WIP
 - Improve video formats support
 - Integrate a test player

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>
