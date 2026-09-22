package dev.metascript.yoga.probe;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public final class MainActivity extends Activity {
	@Override
	protected void onCreate(Bundle state) {
		super.onCreate(state);
		TextView view = new TextView(this);
		view.setText("Yoga Android frame: " + Native.measure());
		view.setContentDescription("yoga-frame-result");
		view.setTextSize(24);
		setContentView(view);
	}
}
