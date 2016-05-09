% Deduplicated Backup Comparison
% draft

I've been on lookup for a fully open source alternative since Tarsnap
popularized deduplicateted backups. I've compared the efficiency
(storage and bandwidth), performance, security and utility of
the main offerings. I'm ignoring what should be every backup system's
most important quality: stability and correctness.

### Test data

The input consists of ten thousand of JPEG images and small H.264
encoded video files totaling 28GB.

```sh
$ du -s media
29201852        media
$ find media -type f | wc -l
10349
```
