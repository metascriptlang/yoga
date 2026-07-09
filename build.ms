import { BuildConfig } from "std/build";

const config: BuildConfig = {
	entry: "./src/index.ms",
	fmt: {
		useTabs: true,
	},
	package: {
		name: "@metascript/yoga",
		version: "0.1.0",
		description: "Yoga flexbox layout engine bindings for MetaScript — React/RN-friendly API over Facebook's C library",
		license: "MIT",
		files: ["src/**/*.ms", "deps/yoga/yoga/**/*.h", "deps/yoga/yoga/YG*.cpp", "deps/yoga/yoga/algorithm/**/*.cpp", "deps/yoga/yoga/config/**/*.cpp", "deps/yoga/yoga/debug/**/*.cpp", "deps/yoga/yoga/event/**/*.cpp", "deps/yoga/yoga/node/**/*.cpp"],
	},
};

export default config;
