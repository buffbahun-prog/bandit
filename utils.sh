loading_animation() {
	while true; do
		echo -ne "$@.  \r"
		sleep 0.5
		echo -ne "$@.. \r"
		sleep 0.5
		echo -ne "$@... \r"
		sleep 0.5
	done
}
