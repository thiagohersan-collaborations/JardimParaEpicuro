public class DataReader {
  private String myUrl;

  private Serial myPort = null;
  private BufferedReader myReader = null;

  private boolean isSerial;
  private String lastLine;

  // initialize a stream reader for web content
  public DataReader(String s_) {
    try {
      this.myUrl = s_;
      this.myReader = new BufferedReader(new InputStreamReader(new URL(s_).openStream()));
      this.myPort = null;
      this.isSerial = false;
    }
    catch(Exception e) {
    }
  }

  // initialize a stream reader for serial port
  public DataReader(Serial p_) {
    this.myUrl = null;
    this.myReader = null;
    this.myPort = p_;
    this.isSerial = true;
  }

  // clear buffer
  private void clear() {
    // clears the buffers by reading until the end
    // keep last line (just in case)
    String tLine;
    if (isSerial == true) {
      tLine = myPort.readStringUntil('\n');
      while (tLine != null) {
        lastLine = tLine;
        tLine = myPort.readStringUntil('\n');
      }
      myPort.clear();
    }
    else {
      try {
        tLine = myReader.readLine();
        while (tLine != null) {
          lastLine = tLine;
          tLine = myReader.readLine();
        }
        myReader.close();
        myReader = new BufferedReader(new InputStreamReader(new URL(myUrl).openStream()));
      }
      catch(Exception e) {
      }
    }
  }

  // return last line of buffer
  public String readLine() {
    this.clear();
    return lastLine;
  }

  //
}

