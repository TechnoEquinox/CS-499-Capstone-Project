package com.baileyconnor.inventoryappv2;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.view.MenuItem;
import android.content.SharedPreferences;
import android.text.Editable;
import android.text.TextWatcher;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.google.android.material.switchmaterial.SwitchMaterial;
import com.google.android.material.textfield.TextInputEditText;

public class NotificationsActivity extends AppCompatActivity {

    private static final String PREFS = "sms_prefs";
    private static final String KEY_LOW_INVENTORY_ENABLED = "low_inv_enabled";
    private static final String KEY_SMS_PHONE = "sms_phone";

    private Chip chipPermissionStatus;
    private MaterialButton enableSMSButton;
    private SwitchMaterial lowInventorySwitch;
    private TextInputEditText phoneEditText;
    private final ActivityResultLauncher<String> requestSmsPermission = registerForActivityResult(new ActivityResultContracts.RequestPermission(),isGranted -> {
        // Check if the user denied with "Don't Ask Again"
        if (!isGranted && !ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.SEND_SMS)) {
            // If this is true, guide the user to Settings
            showGoToSettingsDialog(); // TODO
        }
        updateUiForPermission(); // TODO
    });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.notification_activity);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("SMS Alerts");
        }

        // Bind the views from notification_activity.xml
        chipPermissionStatus = findViewById(R.id.chipPermissionStatus);
        enableSMSButton = findViewById(R.id.enableSMSButton);
        lowInventorySwitch = findViewById(R.id.lowInventorySwitch);
        phoneEditText = findViewById(R.id.phoneEditText);

        String savedPhone = getPrefs().getString(KEY_SMS_PHONE, "");
        if (phoneEditText != null) {
            phoneEditText.setText(savedPhone);
            phoneEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void afterTextChanged(Editable s) {
                    getPrefs().edit().putString(KEY_SMS_PHONE, s == null ? "" : s.toString().trim()).apply();
                }
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {}
            });
        }

        // Event Handler for enableSMSButton
        enableSMSButton.setOnClickListener(v -> {
            if (hasSmsPermission()) {
                updateUiForPermission();
                return;
            }

            if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.SEND_SMS)) {
                showRationaleDialog(); // TODO
            } else {
                requestSmsPermission.launch(Manifest.permission.SEND_SMS);
            }
        });

    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem menuItem) {
        if (menuItem.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    // Update the UI based on permissions granted to the app
    private void updateUiForPermission() {
        boolean granted = hasSmsPermission(); // TODO

        if (chipPermissionStatus != null) {
            chipPermissionStatus.setText(granted ? "Permission: Granted" : "Permission: Denied");
        }

        if (enableSMSButton != null) {
            enableSMSButton.setText(granted ? "SMS Enabled" : "Enable SNS Alerts");
            enableSMSButton.setEnabled(true);
        }

        if (lowInventorySwitch != null) {
            if (granted) {
                boolean saved = getPrefs().getBoolean(KEY_LOW_INVENTORY_ENABLED, false);
                lowInventorySwitch.setChecked(saved);
                lowInventorySwitch.setEnabled(true);
            } else {
                lowInventorySwitch.setChecked(false);
                lowInventorySwitch.setEnabled(false);
            }
        }
    }

    // Show an Alert Dialog with the rational why SMS permissions are needed
    private void showRationaleDialog() {
        new AlertDialog.Builder(this)
                .setTitle("SMS Permission")
                .setMessage("This app uses SMS to send you low-inventory alerts. Without this, we won't be able to send you texts.")
                .setPositiveButton("Continue", (d, w) -> requestSmsPermission.launch(Manifest.permission.SEND_SMS))
                .setNegativeButton("Cancel", null)
                .show();
    }

    // Check if SMS Permissions are enabled
    private boolean hasSmsPermission() {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED;
    }

    // Send the user to the Settings Panel for this app
    // to adjust their previous SMS settings
    private void showGoToSettingsDialog() {
        new AlertDialog.Builder(this)
                .setTitle("Permission Required")
                .setMessage("SMS permission has been denied. You can enable it in the App Settings.")
                .setPositiveButton("Open Settings", (d, w) -> {
                    Intent i = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    i.setData(Uri.fromParts("package", getPackageName(), null));
                    startActivity(i);
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private SharedPreferences getPrefs() {
        return getSharedPreferences(PREFS, MODE_PRIVATE);
    }
}
