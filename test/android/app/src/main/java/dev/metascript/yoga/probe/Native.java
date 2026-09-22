package dev.metascript.yoga.probe;

final class Native {
	static {
		System.loadLibrary("yoga_probe");
	}

	static native String measure();

	private Native() {}
}
