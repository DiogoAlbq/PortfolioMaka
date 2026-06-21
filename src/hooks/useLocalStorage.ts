import { useState, useEffect, Dispatch, SetStateAction } from 'react';

function parseItem<T>(item: string, initialValue: T): T {
  try {
    return JSON.parse(item);
  } catch {
    // If parsing fails and the initial value is a string, assume the raw string is the value
    if (typeof initialValue === 'string') {
      return item as unknown as T;
    }
    return initialValue;
  }
}

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, Dispatch<SetStateAction<T>>] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue;
    const item = window.localStorage.getItem(key);
    return item ? parseItem(item, initialValue) : initialValue;
  });

  const setValue: Dispatch<SetStateAction<T>> = (value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      }
    } catch (error) {
      console.warn(`Error setting localStorage key "${key}":`, error);
    }
  };

  useEffect(() => {
    const item = window.localStorage.getItem(key);
    if (item) {
      setStoredValue(parseItem(item, initialValue));
    }
  }, [key]);

  return [storedValue, setValue];
}