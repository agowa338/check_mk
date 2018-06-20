all: image

image:
	docker build -t agowa338/check_mk:1.5.0b7 -t agowa338/check_mk:latest .

cleanup:
	-docker rmi agowa338/check_mk:latest
	-docker rmi agowa338/check_mk:1.5.0b7
