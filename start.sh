cat start.sh 
docker run \
  -p 8083:8080 \
  -v $(pwd)/config:/config \
  oznu/guacamole