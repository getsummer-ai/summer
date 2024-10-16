export {};
declare global {
  interface Window {
    Chartkick: {
      charts: { [key: string]: never };
      eachChart: (callback: (chart: any) => void) => void;
      config: { autoDestroy: boolean };
    };
    GetSummer: { id: string, settings: object };
    Turbo: {
      navigator: Navigator & {
        history: History & {
          push: (url: string | URL) => void;
          replace: (url: string | URL) => void;
        };
      };
      visit: (s: string, params?: { action: string; frame?: string }) => void;
      setProgressBarDelay: (delay: number) => void;
    };
  }
}
