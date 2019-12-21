all: image

image:
	docker build --build-arg name='CMK_VERSION="1.6.0b7"' -t agowa338/check_mk:1.6.0b7 -t agowa338/check_mk:latest .

cleanup:
	-docker rmi agowa338/check_mk:latest
	-docker rmi agowa338/check_mk:1.6.0b7
