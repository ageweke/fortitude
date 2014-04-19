import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.runtime.load.BasicLibraryService;

public class FortitudeJrubyNativeExtService implements BasicLibraryService {
    public boolean basicLoad(final Ruby runtime) throws IOException {
        new com.fortituderuby.ext.fortitude.FortitudeNativeLibrary().load(runtime, false);
        return true;
    }
}
