/*
 * Copyright (C) 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.zxing.client.android.result;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.preference.PreferenceManager;
import android.provider.ContactsContract;
import android.util.Log;

import com.google.zxing.R;
import com.google.zxing.Result;
import com.google.zxing.client.android.Contents;
import com.google.zxing.client.android.Intents;
import com.google.zxing.client.android.LocaleManager;
import com.google.zxing.client.android.PreferencesActivity;
import com.google.zxing.client.android.book.SearchBookContentsActivity;
import com.google.zxing.client.result.ParsedResult;
import com.google.zxing.client.result.ParsedResultType;
import com.google.zxing.client.result.ResultParser;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Locale;

/**
 * A base class for the Android-specific barcode handlers. These allow the app to polymorphically
 * suggest the appropriate actions for each data type.
 *
 * This class also contains a bunch of utility methods to take common actions like opening a URL.
 * They could easily be moved into a helper object, but it can't be static because the Activity
 * instance is needed to launch an intent.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */
public abstract class ResultHandler {

    private static final String TAG = ResultHandler.class.getSimpleName();

    private static final String[] EMAIL_TYPE_STRINGS = {"home", "work", "mobile"};
    private static final String[] PHONE_TYPE_STRINGS = {"home", "work", "mobile", "fax", "pager", "main"};
    private static final String[] ADDRESS_TYPE_STRINGS = {"home", "work"};
    private static final int[] EMAIL_TYPE_VALUES = {
            ContactsContract.CommonDataKinds.Email.TYPE_HOME,
            ContactsContract.CommonDataKinds.Email.TYPE_WORK,
            ContactsContract.CommonDataKinds.Email.TYPE_MOBILE,
    };
    private static final int[] PHONE_TYPE_VALUES = {
            ContactsContract.CommonDataKinds.Phone.TYPE_HOME,
            ContactsContract.CommonDataKinds.Phone.TYPE_WORK,
            ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE,
            ContactsContract.CommonDataKinds.Phone.TYPE_FAX_WORK,
            ContactsContract.CommonDataKinds.Phone.TYPE_PAGER,
            ContactsContract.CommonDataKinds.Phone.TYPE_MAIN,
    };
    private static final int[] ADDRESS_TYPE_VALUES = {
            ContactsContract.CommonDataKinds.StructuredPostal.TYPE_HOME,
            ContactsContract.CommonDataKinds.StructuredPostal.TYPE_WORK,
    };
    private static final int NO_TYPE = -1;

    public static final int MAX_BUTTON_COUNT = 4;

    private final ParsedResult result;
    private final Activity activity;
    private final Result rawResult;
    private final String customProductSearch;

    ResultHandler(Activity activity, ParsedResult result) {
        this(activity, result, null);
    }

    ResultHandler(Activity activity, ParsedResult result, Result rawResult) {
        this.result = result;
        this.activity = activity;
        this.rawResult = rawResult;
        this.customProductSearch = parseCustomSearchURL();
    }

    public final ParsedResult getResult() {
        return result;
    }

    final boolean hasCustomProductSearch() {
        return customProductSearch != null;
    }

    final Activity getActivity() {
        return activity;
    }

    /**
     * Indicates how many buttons the derived class wants shown.
     *
     * @return The integer button count.
     */
    public abstract int getButtonCount();

    /**
     * The text of the nth action button.
     *
     * @param index From 0 to getButtonCount() - 1
     * @return The button text as a resource ID
     */
    public abstract int getButtonText(int index);

    public Integer getDefaultButtonID() {
        return null;
    }

    /**
     * Execute the action which corresponds to the nth button.
     *
     * @param index The button that was clicked.
     */
    public abstract void handleButtonPress(int index);

    /**
     * Some barcode contents are considered secure, and should not be saved to history, copied to
     * the clipboard, or otherwise persisted.
     *
     * @return If true, do not create any permanent record of these contents.
     */
    public boolean areContentsSecure() {
        return false;
    }

    /**
     * Create a possibly styled string for the contents of the current barcode.
     *
     * @return The text to be displayed.
     */
    public CharSequence getDisplayContents() {
        String contents = result.getDisplayResult();
        return contents.replace("\r", "");
    }

    /**
     * A string describing the kind of barcode that was found, e.g. "Found contact info".
     *
     * @return The resource ID of the string.
     */
    public abstract int getDisplayTitle();

    /**
     * A convenience method to get the parsed type. Should not be overridden.
     *
     * @return The parsed type, e.g. URI or ISBN
     */
    public final ParsedResultType getType() {
        return result.getType();
    }

    final void addPhoneOnlyContact(String[] phoneNumbers, String[] phoneTypes) {
        addContact(null, null, null, phoneNumbers, phoneTypes, null, null, null, null, null, null, null, null, null, null, null);
    }

    final void addEmailOnlyContact(String[] emails, String[] emailTypes) {
        addContact(null, null, null, null, null, emails, emailTypes, null, null, null, null, null, null, null, null, null);
    }

    final void addContact(String[] names,
                          String[] nicknames,
                          String pronunciation,
                          String[] phoneNumbers,
                          String[] phoneTypes,
                          String[] emails,
                          String[] emailTypes,
                          String note,
                          String instantMessenger,
                          String address,
                          String addressType,
                          String org,
                          String title,
                          String[] urls,
                          String birthday,
                          String[] geo) {

        // Only use the first name in the array, if present.
        Intent intent = new Intent(Intent.ACTION_INSERT_OR_EDIT, ContactsContract.Contacts.CONTENT_URI);
        intent.setType(ContactsContract.Contacts.CONTENT_ITEM_TYPE);
        putExtra(intent, ContactsContract.Intents.Insert.NAME, names != null ? names[0] : null);

        putExtra(intent, ContactsContract.Intents.Insert.PHONETIC_NAME, pronunciation);

        int phoneCount = Math.min(phoneNumbers != null ? phoneNumbers.length : 0, Contents.PHONE_KEYS.length);
        for (int x = 0; x < phoneCount; x++) {
            putExtra(intent, Contents.PHONE_KEYS[x], phoneNumbers[x]);
            if (phoneTypes != null && x < phoneTypes.length) {
                int type = toPhoneContractType(phoneTypes[x]);
                if (type >= 0) {
                    intent.putExtra(Contents.PHONE_TYPE_KEYS[x], type);
                }
            }
        }

        int emailCount = Math.min(emails != null ? emails.length : 0, Contents.EMAIL_KEYS.length);
        for (int x = 0; x < emailCount; x++) {
            putExtra(intent, Contents.EMAIL_KEYS[x], emails[x]);
            if (emailTypes != null && x < emailTypes.length) {
                int type = toEmailContractType(emailTypes[x]);
                if (type >= 0) {
                    intent.putExtra(Contents.EMAIL_TYPE_KEYS[x], type);
                }
            }
        }

        ArrayList<ContentValues> data = new ArrayList<>();
        if (urls != null) {
            for (String url : urls) {
                if (url != null && !url.isEmpty()) {
                    ContentValues row = new ContentValues(2);
                    row.put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE);
                    row.put(ContactsContract.CommonDataKinds.Website.URL, url);
                    data.add(row);
                    break;
                }
            }
        }

        if (birthday != null) {
            ContentValues row = new ContentValues(3);
            row.put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE);
            row.put(ContactsContract.CommonDataKinds.Event.TYPE, ContactsContract.CommonDataKinds.Event.TYPE_BIRTHDAY);
            row.put(ContactsContract.CommonDataKinds.Event.START_DATE, birthday);
            data.add(row);
        }

        if (nicknames != null) {
            for (String nickname : nicknames) {
                if (nickname != null && !nickname.isEmpty()) {
                    ContentValues row = new ContentValues(3);
                    row.put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE);
                    row.put(ContactsContract.CommonDataKinds.Nickname.TYPE,
                            ContactsContract.CommonDataKinds.Nickname.TYPE_DEFAULT);
                    row.put(ContactsContract.CommonDataKinds.Nickname.NAME, nickname);
                    data.add(row);
                    break;
                }
            }
        }

        if (!data.isEmpty()) {
            intent.putParcelableArrayListExtra(ContactsContract.Intents.Insert.DATA, data);
        }

        StringBuilder aggregatedNotes = new StringBuilder();
        if (note != null) {
            aggregatedNotes.append('\n').append(note);
        }
        if (geo != null) {
            aggregatedNotes.append('\n').append(geo[0]).append(',').append(geo[1]);
        }

        if (aggregatedNotes.length() > 0) {
            // Remove extra leading '\n'
            putExtra(intent, ContactsContract.Intents.Insert.NOTES, aggregatedNotes.substring(1));
        }

        putExtra(intent, ContactsContract.Intents.Insert.IM_HANDLE, instantMessenger);
        putExtra(intent, ContactsContract.Intents.Insert.POSTAL, address);
        if (addressType != null) {
            int type = toAddressContractType(addressType);
            if (type >= 0) {
                intent.putExtra(ContactsContract.Intents.Insert.POSTAL_TYPE, type);
            }
        }
        putExtra(intent, ContactsContract.Intents.Insert.COMPANY, org);
        putExtra(intent, ContactsContract.Intents.Insert.JOB_TITLE, title);
        launchIntent(intent);
    }

    private static int toEmailContractType(String typeString) {
        return doToContractType(typeString, EMAIL_TYPE_STRINGS, EMAIL_TYPE_VALUES);
    }

    private static int toPhoneContractType(String typeString) {
        return doToContractType(typeString, PHONE_TYPE_STRINGS, PHONE_TYPE_VALUES);
    }

    private static int toAddressContractType(String typeString) {
        return doToContractType(typeString, ADDRESS_TYPE_STRINGS, ADDRESS_TYPE_VALUES);
    }

    private static int doToContractType(String typeString, String[] types, int[] values) {
        if (typeString == null) {
            return NO_TYPE;
        }
        for (int i = 0; i < types.length; i++) {
            String type = types[i];
            if (typeString.startsWith(type) || typeString.startsWith(type.toUpperCase(Locale.ENGLISH))) {
                return values[i];
            }
        }
        return NO_TYPE;
    }

    final void shareByEmail(String contents) {
        sendEmail(null, null, null, null, contents);
    }

    final void sendEmail(String[] to,
                         String[] cc,
                         String[] bcc,
                         String subject,
                         String body) {
        Intent intent = new Intent(Intent.ACTION_SEND, Uri.parse("mailto:"));
        if (to != null && to.length != 0) {
            intent.putExtra(Intent.EXTRA_EMAIL, to);
        }
        if (cc != null && cc.length != 0) {
            intent.putExtra(Intent.EXTRA_CC, cc);
        }
        if (bcc != null && bcc.length != 0) {
            intent.putExtra(Intent.EXTRA_BCC, bcc);
        }
        putExtra(intent, Intent.EXTRA_SUBJECT, subject);
        putExtra(intent, Intent.EXTRA_TEXT, body);
        intent.setType("text/plain");
        launchIntent(intent);
    }

    final void shareBySMS(String contents) {
        sendSMSFromUri("smsto:", contents);
    }

    final void sendSMS(String phoneNumber, String body) {
        sendSMSFromUri("smsto:" + phoneNumber, body);
    }

    final void sendSMSFromUri(String uri, String body) {
        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse(uri));
        putExtra(intent, "sms_body", body);
        // Exit the app once the SMS is sent
        intent.putExtra("compose_mode", true);
        launchIntent(intent);
    }

    final void sendMMS(String phoneNumber, String subject, String body) {
        sendMMSFromUri("mmsto:" + phoneNumber, subject, body);
    }

    final void sendMMSFromUri(String uri, String subject, String body) {
        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse(uri));
        // The Messaging app needs to see a valid subject or else it will treat this an an SMS.
        if (subject == null || subject.isEmpty()) {
            putExtra(intent, "subject", activity.getString(R.string.msg_default_mms_subject));
        } else {
            putExtra(intent, "subject", subject);
        }
        putExtra(intent, "sms_body", body);
        intent.putExtra("compose_mode", true);
        launchIntent(intent);
    }

    final void dialPhone(String phoneNumber) {
        launchIntent(new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + phoneNumber)));
    }

    final void dialPhoneFromUri(String uri) {
        launchIntent(new Intent(Intent.ACTION_DIAL, Uri.parse(uri)));
    }

    final void openMap(String geoURI) {
        launchIntent(new Intent(Intent.ACTION_VIEW, Uri.parse(geoURI)));
    }

    /**
     * Do a geo search using the address as the query.
     *
     * @param address The address to find
     */
    final void searchMap(String address) {
        launchIntent(new Intent(Intent.ACTION_VIEW, Uri.parse("geo:0,0?q=" + Uri.encode(address))));
    }

    final void getDirections(double latitude, double longitude) {
        launchIntent(new Intent(Intent.ACTION_VIEW, Uri.parse("http://maps.google." +
                LocaleManager.getCountryTLD(activity) + "/maps?f=d&daddr=" + latitude + ',' + longitude)));
    }

    // Uses the mobile-specific version of Product Search, which is formatted for small screens.
    final void openProductSearch(String upc) {
        Uri uri = Uri.parse("http://www.google." + LocaleManager.getProductSearchCountryTLD(activity) +
                "/m/products?q=" + upc + "&source=zxing");
        launchIntent(new Intent(Intent.ACTION_VIEW, uri));
    }

    final void openBookSearch(String isbn) {
        Uri uri = Uri.parse("http://books.google." + LocaleManager.getBookSearchCountryTLD(activity) +
                "/books?vid=isbn" + isbn);
        launchIntent(new Intent(Intent.ACTION_VIEW, uri));
    }

    final void searchBookContents(String isbnOrUrl) {
        Intent intent = new Intent(Intents.SearchBookContents.ACTION);
        intent.setClassName(activity, SearchBookContentsActivity.class.getName());
        putExtra(intent, Intents.SearchBookContents.ISBN, isbnOrUrl);
        launchIntent(intent);
    }

    final void openURL(String url) {
        // Strangely, some Android browsers don't seem to register to handle HTTP:// or HTTPS://.
        // Lower-case these as it should always be OK to lower-case these schemes.
        if (url.startsWith("HTTP://")) {
            url = "http" + url.substring(4);
        } else if (url.startsWith("HTTPS://")) {
            url = "https" + url.substring(5);
        }
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        try {
            launchIntent(intent);
        } catch (ActivityNotFoundException ignored) {
            Log.w(TAG, "Nothing available to handle " + intent);
        }
    }

    final void webSearch(String query) {
        Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
        intent.putExtra("query", query);
        launchIntent(intent);
    }

    /**
     * Like {@link #launchIntent(Intent)} but will tell you if it is not handle-able
     * via {@link ActivityNotFoundException}.
     *
     * @throws ActivityNotFoundException
     */
    final void rawLaunchIntent(Intent intent) {
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
            Log.d(TAG, "Launching intent: " + intent + " with extras: " + intent.getExtras());
            activity.startActivity(intent);
        }
    }

    /**
     * Like {@link #rawLaunchIntent(Intent)} but will show a user dialog if nothing is available to handle.
     */
    final void launchIntent(Intent intent) {
        try {
            rawLaunchIntent(intent);
        } catch (ActivityNotFoundException ignored) {
            AlertDialog.Builder builder = new AlertDialog.Builder(activity);
//            builder.setTitle(R.string.app_name);
            builder.setMessage(R.string.msg_intent_failed);
            builder.setPositiveButton(R.string.button_ok, null);
            builder.show();
        }
    }

    private static void putExtra(Intent intent, String key, String value) {
        if (value != null && !value.isEmpty()) {
            intent.putExtra(key, value);
        }
    }

    private String parseCustomSearchURL() {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(activity);
        String customProductSearch = prefs.getString(PreferencesActivity.KEY_CUSTOM_PRODUCT_SEARCH,
                null);
        if (customProductSearch != null && customProductSearch.trim().isEmpty()) {
            return null;
        }
        return customProductSearch;
    }

    final String fillInCustomSearchURL(String text) {
        if (customProductSearch == null) {
            return text; // ?
        }
        try {
            text = URLEncoder.encode(text, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            // can't happen; UTF-8 is always supported. Continue, I guess, without encoding
        }
        String url = customProductSearch;
        if (rawResult != null) {
            // Replace %f but only if it doesn't seem to be a hex escape sequence. This remains
            // problematic but avoids the more surprising problem of breaking escapes
            url = url.replaceFirst("%f(?![0-9a-f])", rawResult.getBarcodeFormat().toString());
            if (url.contains("%t")) {
                ParsedResult parsedResultAgain = ResultParser.parseResult(rawResult);
                url = url.replace("%t", parsedResultAgain.getType().toString());
            }
        }
        // Replace %s last as it might contain itself %f or %t
        return url.replace("%s", text);
    }

}
