export {};
declare global {
  interface Window {
    GetSummer: { key: string };
    Turbo: {
      navigator: Navigator & {
        history: History & {
          push: (url: string | URL) => void;
          replace: (url: string | URL) => void;
        };
      };
      visit: (s: string, params: { action: string; frame?: string }) => void;
      setProgressBarDelay: (delay: number) => void;
    };
  }
}
