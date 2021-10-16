
### Hotel Transylvania

```
imf = Imf::ImfParser.new('wuakidevstpeter', 'g/pack/IMF/hotel_transylvania/hotel_transylvania_hdr_185/')
cpl = imf.cpls.find {|cpl| cpl.id == 'urn:uuid:020acb2b-88a8-4bf2-a6d5-d96d51d3fbce'}
Ffmpeg::ConcatGenerator.new(cpl.main_image_sequences.first).call
```


### New Mutants

```
imf = Imf::ImfParser.new('wuakidevstpeter', 'g/pack/IMF/NOMADLAND_43654_English_RAKUTEN_4506420635/')
Ffmpeg::ConcatGenerator.new(imf.cpls.first.main_image_sequences.first).call
```

### New Mutants WuakiZombies

#### SDR

```
imf = Imf::ImfParser.new('wuakizombies', 'roushi/prod/masters/disn/TheNew_mutants_TEST/TheNewMutants_44223_CSP_SDR_Rakuten/')
Ffmpeg::ConcatGenerator.new(imf.cpls.first.main_image_sequences.first).call
```

#### HDR

```
imf = Imf::ImfParser.new('wuakizombies', 'roushi/prod/masters/disn/TheNew_mutants_TEST/TheNewMutants_44228_CSP_HDR_Rakuten/')
Ffmpeg::ConcatGenerator.new(imf.cpls.first.main_image_sequences.first).call

```

Run demo with 
```
bundle exec ruby integration/test.rb
```

